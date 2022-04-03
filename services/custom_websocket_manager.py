from parlai.chat_service.services.websocket.websocket_manager import WebsocketManager
from parlai.chat_service.services.websocket.sockets import MessageSocketHandler
import tornado
from tornado.options import options

class CustomWebsocketManager(WebsocketManager):

    def _make_app(self):
        """
        Starts the tornado application.
        """
        message_callback = self._on_new_message

        options['log_to_stderr'] = True
        tornado.options.parse_command_line([])

        return tornado.web.Application(
            [
                (
                    r"/",
                    MessageSocketHandler,
                    {'subs': self.subs, 'message_callback': message_callback},
                )
            ],
            debug=self.debug,
        )
