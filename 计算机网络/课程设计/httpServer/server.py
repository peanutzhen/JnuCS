from socket import socket, AF_INET, SOCK_STREAM
import os
import sys

def request_handler():
    from flask import Flask as parse
    from flask import render_template as warp
    from flask import send_file as response
    request = parse(__name__)
    request.template_folder = '.'

    @request.route('/')
    def index():
        return warp('index.html')
    
    @request.route('/me.png')
    def me():
        return response('me.png')
    
    request.run("127.0.0.1", 6324)

if __name__ == "__main__":
    s = socket(AF_INET, SOCK_STREAM,0)
    s.bind(("127.0.0.1",6325))
    s.listen(1024)
    while True:
        rtv = request_handler()
        if rtv < 0:
            break
    print('Bye')