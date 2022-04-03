#!/usr/bin/env python3

from typing import Dict, TypeVar
import uuid
import logging

def get_rand_id():
    return str(uuid.uuid4())


T = TypeVar('T', bound='MessageApiHandler')


class MessageApiHandler:
    def __init__(self: T, *args, **kwargs):
        self.subs: Dict[int, T] = kwargs.pop('subs')

        def _default_callback(message, socketID):
            logging.warning(f"No callback defined for new messages.")

        self.message_callback = kwargs.pop('message_callback', _default_callback)
        self.sid = get_rand_id()
        super().__init__(*args, **kwargs)

    def open(self):
        """
        Opens a websocket and assigns a random UUID that is stored in the class-level
        `subs` variable.
        """
        if self.sid not in self.subs.values():
            self.subs[self.sid] = self
            logging.info(f"Current subscribers: {self.subs}")

    def on_close(self):
        """
        Runs when a socket is closed.
        """
        del self.subs[self.sid]

    def on_message(self, message_text):
        """
        Callback that runs when a new message is received from a client See the
        chat_service README for the resultant message structure.

        Args:
            message_text: A stringified JSON object with a text or attachment key.
                `text` should contain a string message and `attachment` is a dict.
                See `WebsocketAgent.put_data` for more information about the
                attachment dict structure.
        """
        logging.info('message from client: {}'.format(message_text))
        message = message_text
        message = {
            'text': message.get('text', ''),
            'payload': message.get('payload'),
            'sender': {'id': self.sid},
            'recipient': {'id': 0},
        }
        self.message_callback(message)
