[Caleb] Are you really planning to go down there?

VAR argue_SAM = true
VAR catchup_Nora = false

* [Yea, of course (+)]
    [Olivia] Yea, of course we are.
    
    [Sam] Yup. We're going into the super dangerous sub-basement. And it's definitely not a rash decision.
    
        ** [It isn't rash! (+)]
            [Olivia] I'm not being rash.
            
            [Sam] That's what I said. 
            You gave it a whole 10 seconds of thought. That's the opposite of being impulsive.
            
            [Olivia] {argue_SAM: No one's asking you to come along, Sam. So keep it to yourself. | Whatever, I'm still going.}
            ->basement_cult_convo1
            
        ** [Ignore him. (+)]
            [Olivia]...
            
            [Sam] Ooh, the silent treatment. That's almost nostalgic.
            
            [Olivia] {argue_SAM: ... | Give it a rest, Sam.}
            
             ->basement_cult_convo1
    
* [We might as well.]
    [Olivia] We're already here, we might as well. 
    I can't think of anything else I'd rather do than climb into that musky under-basement.
    
    [Rowan] I could think of a few things...but I'll keep them to myself.
    
        ** [What could be more important?]
            [Olivia] Something more important than solving the mystery of your missing friend?
            
            [Rowan] Well, when you put it like that...
            ->basement_cult_convo1
        
        ** [Would you rather?]
            [Olivia] That sounds like a set up for a traumatizing game of "would you rather."
            
            [Rowan] It does, doesn't it?
            Should we play that instead?
            
            [Olivia] How about we compromise and play on the way?
            ->basement_cult_convo1
    
* [You don't think we should?]
    [Olivia] You don't think we should?
    
    [Nora] Don't worry so much, Caleb. We'll be fine.
    
        ** [If you're that worried...]
            [Olivia] If you're that worried, why don't you just come with us?
            
            [Caleb] I would, but...
            
            [Nora] I really don't think he needs to?
            ->basement_cult_convo1
        
        ** [Nora, maybe you should stay behind.]
            [Olivia] Nora, maybe you should stay behind? Caleb's obviously worried about you. 
            
            [Nora] No way, I'm coming with you! Kyle was my friend, and so are you. 
            ->basement_cult_convo1


=basement_cult_convo1
[Caleb] I guess I can't stop you, but I also can't go with you. 
I mean, I liked the guy and all. He was great! One of the best of us. But I can't be gone from the party for that long. 
Plus, that place gives me the creeps.

[Rowan] We get it, Caleb. Don't worry about it.

[Sam] It's probably not a cult, anyway. You should probably start thinking about how the frat can repay us for proving it's all rumors.

[Caleb] Haha...yea, you're right. I'll give it some thought.
...
Nora, do you have a minute? I was hoping we could talk about...

[Nora]...?

{catchup_Nora:
    * [You OK, Nora? (++)]
        [Olivia] Are you OK with this, Nora? Do you want us to stay with you?
        
        [Sam] Yea, this guy botherin' you or somethin'?
        
        [Rowan]...why do you two only agree on the dumbest things? 
        Nora, we'll be over here if you need us--not listening.
        
        ->basement_cult_convo2
  - else:
    * [Just leave]
        /leaves scene & convo
        ->basement_cult_convo2
}

* [We can all hear you.]
    [Olivia] *clears throat*
    We can still hear you guys...
    ->basement_cult_convo2
    
* [Do you need some privacy?]
    [Olivia] We can give you two some privacy if you want?
    
    ->basement_cult_convo2
    
 
    =basement_cult_convo2
[Caleb] Uh...nevermind.

[Nora] So much for a proper convo.




    -> END
