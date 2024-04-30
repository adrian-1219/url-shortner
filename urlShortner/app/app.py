from flask import Flask, jsonify, make_response, render_template, request, redirect
from redis import Redis, RedisError
from cassandra.cluster import Cluster
import socket
import os

app = Flask(__name__)

# VERSION 1 Write request goes to cassandra to perform the write, 
# if request is an update to existing data, we can either delete it from redis or update it, respond ok to client\

hostname=socket.gethostname()
cluster = Cluster(['10.128.1.113', '10.128.3.113', '10.128.4.113']) 
session = cluster.connect('a2_keyspace')

redis_master = Redis(host="redis_master", db=0, password="password", socket_connect_timeout=2, socket_timeout=2)
redis_replica = Redis(host="redis_replica", db=0, password="password", socket_connect_timeout=2, socket_timeout=2)

# Route for GET request /XYZ
@app.route('/<short_url>', methods=['GET'])
def handle_get_request(short_url):
    f = open("logs/log.txt", "a")
    if request.method == 'GET':
        long_url = get_long_url_from_short_url(short_url, f)
        if long_url:
            f.write("%s get request LONG URL FOUND %s %s \n" % (hostname, short_url, long_url))
            f.close()
            return redirect(long_url, code=307)  # Redirect to the long URL
        else:
            f.write("%s get request LONG URL NOT FOUND %s \n" % (hostname, short_url))
            response = make_response(render_template('404.html'), 404)
            response.headers["Content-Type"] = "text/html"
            f.close()
            return response 
    else:
        f.write("%s get request BAD FORMAT \n" % (hostname))
        response = make_response(render_template('400.html'), 400)
        response.headers["Content-Type"] = "text/html"
        f.close()
        return response


# Route for PUT requests /?short=XYZ&long=ABC
@app.route('/', methods =['GET', 'PUT'])
def handle_put_request():
    f = open("logs/log.txt", "a")
    if request.method == 'PUT':
        short_url = request.args.get('short')
        long_url = request.args.get('long')
        if short_url and long_url:
            f.write("%s put request SAVED %s %s " % (hostname, short_url, long_url))
            save_mapping(short_url, long_url, f)
            response = make_response(render_template('200.html'), 200)
            response.headers["Content-Type"] = "text/html"
            return response
        f.write("%s put request BAD FORMAT \n" % (hostname))
        f.close()
        response = make_response(render_template('400.html'), 400)
        response.headers["Content-Type"] = "text/html"
        return response
    elif request.method == 'GET':
        response = make_response(render_template('200.html'), 200)
        response.headers["Content-Type"] = "text/html"
        f.close()
        return response

def get_long_url_from_short_url(short_url, f):
    try:
        if redis_replica.exists(short_url):
            f.write(" HIT CACHE ")
            return redis_replica.get(short_url)
        else:
            f.write(" DID NOT HIT CACHE ")
            query = f"SELECT long FROM a2_keyspace.urls WHERE short = '{short_url}'"
            result = session.execute(query)
            if result:
                f.write("IN CASSANDRA")
                long_url = result.one().long
                redis_master.set(short_url, long_url)
                return long_url
            f.write("NOT IN CASSANDRA")
            return None
    except RedisError:
        f.write("REDIS ERROR, CHECKING CASSANDRA\n")
        query = f"SELECT long FROM a2_keyspace.urls WHERE short = '{short_url}'"
        result = session.execute(query)
        return result.one().long if result else None


def save_mapping(short_url, long_url, f):
    redis_master.set(short_url, long_url)
    f.write("WRITE SHORT/LONG PAIR TO CASSANDRA & REDIS\n")
    query = f"INSERT INTO a2_keyspace.urls (short, long) VALUES ('{short_url}', '{long_url}')"
    session.execute(query)


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
