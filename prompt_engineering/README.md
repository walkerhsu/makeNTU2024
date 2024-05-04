# Prompt Engineering
## outline.py
`python3 outline.py > outline.json`
output format:
```
{
    "introduction": the introduction of this story,
    "outline": {
        "beginning": [] two stages of story and one stage of battle,
        "middle": [] two stages of story and one stage of battle,
        "ending": [] two stages of story and one stage of final battle
    }
}
```
## story.py
input format:
```
{
"Previous Choice": The option we selected. Leave empty if nothing.
, "Current Outline": The outline of the current story the assistant should generate.
, "Next Outline": The next outline that options should lead to.
, "Elements": Observed things. If not empty, they will be added to the story.
, "Status": Start: start of the story, Battle: should involve battle, Win/Lose: we win/lose the provious battle, End: the story should end after this part of story being generated.
}
```
output format:
```
{
"Story": The generated story.
,"Options":[] four options that can be chosen.
, "Status": Battle: encounter a battle, End: the story ends.
}
```