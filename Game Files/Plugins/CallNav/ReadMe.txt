New commands and layout Layout for NPC's

pbPhoneRegisterNPCNav(3,"Brendan",42,4,"Hoenn")
		      1	    2	  3  4  5
 
Some of this code has remained the same however you'll see a new set of numbers.
1 = Common Event
2 = Registered Name
3 = Map ID
4 = Event ID
5 = NPC Tag

"NPC Tag"
The NPC tag is used in sevral areas such as to keep Dynamic NPC icon names from using the same icon or adjusting NPC information.

---
Adding NPC
This new method of NPC Registration is expanded from the classic allowing for advanced options compared to the classic pokegear Phone

pbPhoneRegisterNPCNav("Common event No.","Name","MAp ID",Event ID","NPC TAG")
---

---
Registering a variable Name
In this example we will be using the rival as the variable name by adding the NPC tag "Rival" we can keep it from causing visual errors should the name match another NPC. 
pbPhoneRegisterNPCNav(4,pbGet(12),4,1,"Rival")
---

---
Registering NPC without an annoucment.
pbPhoneRegisterNPCSilent(1, "Professor Oak", 4, "")
---

---
Edit an existing NPC
Using the example at the top of the page, you can use the NPC tag as a way to further alter an existing record of an existing NPC
 
pbPhoneModifyNPCmap(3,"Brendan",43,1,"Hoenn")

In the above code we have changed Brendan from map id 42 to map id 43 without having to unregistering and then re-registering the NPC.
--

Trainer Battles
The setup is the same as the classic pokegear. If you do not wish to use the pokegear and so the player doesn't have the item you can do the following:
in each trainer replace the line

pbPhoneRegisterBattle()

with

pbPhoneRegisterBattleNav()

While it will register to both phone UI's it will change what item is detected for registration.