# parlai-bots

Make sure that is repository live in https://github.com/facebookresearch/ParlAI/parlai_internal

```bash
make install
```


## Sync upstream

```bash
git remote add upstream https://github.com/facebookresearch/ParlAI
git fetch upstream
git checkout main
git rebase upstream/main
```

## Getting started

```bash
python3 run.py --config_path=tasks/ava/config.yaml --port 8080
```

In another terminal:
```bash
python3 scripts/client.py
# begin
# begin
# Hi, my name is Louis, I am a space explorer, currently between Mars and Jupyter, do you have an idea where I can grab some food?
# That's great, where I am at the moment is a planet called Mars which isn't good for eating and has no food.
```

## TODO

- [ ] deploy a HUGE blenderbot2 on k8s and connect to langame
