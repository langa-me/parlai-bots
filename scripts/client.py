"""
This is a basic websocket Python client that connects to a websocket server.
"""

import fire
import websocket
import json
import time

def talk(host: str = "ws://localhost", port: int = 8083):
    """
    Connect to a websocket server and send a message.
    """
    ws = websocket.WebSocket()
    tries = 0
    max_tries = 3
    while tries < max_tries:
        try:
            ws.connect(f"{host}:{port}")
            break
        except:
            if tries == max_tries - 1:
                raise RuntimeError(f"Could not connect to {host}:{port}")
            tries += 1
            print(f"Failed to connect to {host}:{port}, retrying {tries}/{max_tries}")
            time.sleep(tries**2)
            continue
    while True:
        message = input("Enter a message: ")
        ws.send(json.dumps({"text": message}))
        result = ws.recv()
        print(result)
    ws.close()


if __name__ == "__main__":
    fire.Fire(talk)
