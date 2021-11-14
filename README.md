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
