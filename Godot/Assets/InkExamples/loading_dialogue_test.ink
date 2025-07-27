VAR has_item_flag = false
VAR die_roll_flag = false
[Kyle] Loading conversations now...
/load_chat Caleb loaded_dialogue.json
/load_phone_chat Caleb loaded_dialogue.json
/give_item Key
/has_item Key
{has_item_flag: You have a key | You don't have a key} //should say "You have a key"
/die_roll intelligence medium
{die_roll_flag: You succeeded on your roll | You failed your roll}
/give_task "First task"
->END

VAR has_key = false
/has_item Key
~has_key = has_item_flag //saves result from has_item_flag for later use
{has_item_flag: You have a key | You don't have a key}
/has_item Book
{has_item_flag: You have a book | You don't have a book}