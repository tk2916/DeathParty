VAR has_key = false
VAR die_roll_flag = false
VAR knows_caleb_is_sad = false

[Caleb] Hi!
How's it going?
/has_item Key has_key //will store true or false in has_key (normally stores it in has_item_flag)
+ Good -> good
+ Bad -> bad
+ {has_key} I have this weird key... //will only show up if player has key

=== good ===
[Olivia] I'm feeling good.
[Caleb] That's great!
/die_roll empathy medium
{die_roll_flag: 
[EMPATHY: SUCCEEDED] He doesn't look so good.
~knows_caleb_is_sad = true
-else:
He smiles.
}
-> END

+ {knows_caleb_is_sad} Why the long face?
[Caleb] Ugh life sucks. Here, have a pill.
/give_item "Pill Bottle"
-> END
+ Ok, bye!
-> END


=== bad ===
[Olivia] I'm doing bad.
[Caleb] Oh no! You gotta take care of yourself. Go talk to Nora, she knows self-help things better than I do.
/give_task "Self Help" //"Self Help" will appear in task list
/load_chat Nora self_help_nora.json //the conversation stored in self_help_nora.json will be added to Nora's conversation queue (when the player interacts with her, the first dialogue off the queue will start)
-> END