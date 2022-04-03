#!/usr/bin/env python3

"""
API Chat Runner.

Used to run the API chat server.
"""

from parlai.core.params import ParlaiParser
from parlai_internal.services.api.api_manager import ApiManager
import parlai.chat_service.utils.config as config_utils


SERVICE_NAME = 'api'


def setup_args():
    """
    Set up args.

    :return: A parser that takes in command line arguments for chat services (debug, config-path, password), and a port.
    """
    parser = ParlaiParser(False, False)
    parser.add_parlai_data_path()
    parser.add_chatservice_args()
    return parser.parse_args()


def run(opt):
    """
    Run TerminalManager.
    """
    opt['service'] = SERVICE_NAME
    manager = ApiManager(opt)
    try:
        manager.start_task()
        print(manager._on_first_message({"text": "Hello world!", "sender": {"id": "1"}, "recipient": {"id": "2"}}))
        print(manager._on_new_message({"text": "Hello world!", "sender": {"id": "1"}, "recipient": {"id": "2"}}))
        import time
        time.sleep(5)
        print(manager.observe_message("1", "Hello world!"))
        time.sleep(5)
    finally:
        manager.shutdown()


if __name__ == '__main__':
    opt = setup_args()
    config_path = opt.get('config_path')
    config = config_utils.parse_configuration_file(config_path)
    opt.update(config['world_opt'])
    opt['config'] = config
    run(opt)
