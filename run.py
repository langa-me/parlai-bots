#!/usr/bin/env python3

"""
Websocket Runner.
"""
from parlai.core.params import ParlaiParser
from parlai_internal.services import CustomWebsocketManager
import parlai.chat_service.utils.config as config_utils


SERVICE_NAME = 'websocket'


def setup_args():
    """
    Set up args.
    """
    parser = ParlaiParser(False, False)
    parser.add_parlai_data_path()
    parser.add_websockets_args()
    parser.add_model_args()
    return parser.parse_args()


def run(opt):
    """
    Run MessengerManager.
    """
    opt['service'] = SERVICE_NAME
    manager = CustomWebsocketManager(opt)
    try:
        manager.start_task()
    except BaseException:
        raise
    finally:
        manager.shutdown()


if __name__ == '__main__':
    opt = setup_args()
    config_path = opt.get('config_path')
    config = config_utils.parse_configuration_file(config_path)
    opt.update(config['world_opt'])
    opt['config'] = config
    run(opt)
