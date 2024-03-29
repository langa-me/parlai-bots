#!/usr/bin/env python3

from parlai.core.worlds import World
from parlai.core.agents import create_agent_from_shared, Agent
from parlai.core.torch_agent import TorchAgent
from parlai.chat_service.services.websocket.agents import WebsocketAgent
from projects.seeker.agents.seeker import SeekerAgent
from parlai.agents.transformer.transformer import TransformerGeneratorAgent

class AvaOnboardWorld(World):
    def __init__(self, opt, agent):
        self.agent = agent
        self.episodeDone = False

    @staticmethod
    def generate_world(opt, agents):
        return AvaOnboardWorld(opt, agents[0])

    def parley(self):
        self.episodeDone = True

    def episode_done(self):
        return self.episodeDone

    def shutdown(self):
        pass


class AvaTaskWorld(World):
    """
    Example one person world that talks to a provided agent (bot).
    """

    MAX_AGENTS = 1
    MODEL_KEY = 'langame'

    def __init__(self, opt, agent: WebsocketAgent, bot):
        self.agent: WebsocketAgent = agent
        self.episodeDone = False
        self.model: TransformerGeneratorAgent = bot
        self.first_time = True

    @staticmethod
    def generate_world(opt, agents):
        if opt['models'] is None:
            raise RuntimeError("Model must be specified")
        return AvaTaskWorld(
            opt,
            agents[0],
            create_agent_from_shared(
                opt['shared_bot_params'][AvaTaskWorld.MODEL_KEY]
            ),
        )

    @staticmethod
    def assign_roles(agents):
        agents[0].disp_id = 'ChatbotAgent'

    def parley(self):
        if self.first_time:
            self.agent.observe(
                {
                    'id': 'World',
                    'text': 'Welcome to Langame ava. '
                    'Type [DONE] to finish the chat, or [RESET] to reset the dialogue history.',
                }
            )
            self.first_time = False
        a = self.agent.act()
        if a is not None:
            if '[CONTEXT]' in a['text']:
                # insert some history in the bot
                a['text'] = a['text'].replace('[CONTEXT]', '')
                self.model.history.add_reply(a['text'])
                self.agent.observe({"text": "[CONTEXT INSERTED]", "episode_done": False})
            elif '[DONE]' in a['text']:
                self.episodeDone = True
            elif '[RESET]' in a['text']:
                self.model.reset()
                self.agent.observe({"text": "[History Cleared]", "episode_done": False})
            else:
                self.model.observe(a)
                response = self.model.act()
                self.agent.observe(response)

    def episode_done(self):
        return self.episodeDone

    def shutdown(self):
        self.agent.shutdown()


class AvaMessengerOverworld(World):
    """
    World to handle moving agents to their proper places.
    """

    def __init__(self, opt, agent):
        self.agent = agent
        self.opt = opt
        self.first_time = True
        self.episodeDone = False

    @staticmethod
    def generate_world(opt, agents):
        return AvaMessengerOverworld(opt, agents[0])

    @staticmethod
    def assign_roles(agents):
        for a in agents:
            a.disp_id = 'Agent'

    def episode_done(self):
        return self.episodeDone

    def parley(self):
        if self.first_time:
            self.agent.observe(
                {
                    'id': 'Overworld',
                    'text': 'Welcome to the Langame Ava overworld. '
                    'Please type "begin" to start, or "exit" to exit',
                    'quick_replies': ['begin', 'exit'],
                }
            )
            self.first_time = False
        a = self.agent.act()
        if a is not None and a['text'].lower() == 'exit':
            self.episodeDone = True
            return 'EXIT'
        if a is not None and a['text'].lower() == 'begin':
            self.episodeDone = True
            return 'default'
        elif a is not None:
            self.agent.observe(
                {
                    'id': 'Overworld',
                    'text': 'Invalid option. Please type "begin".',
                    'quick_replies': ['begin'],
                }
            )
