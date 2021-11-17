# parlai-bots

Make sure that is repository live in https://github.com/facebookresearch/ParlAI/parlai_internal

```bash
cd ..
python3 -m virtualenv env
source env/bin/activate
python3 -m pip install -e .
```


## Sync upstream

```bash
git remote add upstream https://github.com/facebookresearch/ParlAI
git fetch upstream
git checkout main
git rebase upstream/main
```

## Basic calls

```bash
websocat ws://0.0.0.0:8080/websocket
# {"text": "begin"}
# {"text": "begin"}
# {"text": "Hi, my name is Louis, I am a space explorer, currently between Mars and Jupyter, do you have an idea where I can grab some food?"}
# {"text": "That ' s great , where I am at the moment is a planet called Mars which isn ' t good for eating and has no food."}
```