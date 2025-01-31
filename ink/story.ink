VAR hi = false
VAR how = false

-> TestA

=== TestA ===
	+	{ not hi } Hi
		Popsy: Hi!
		~ hi = true
		-> TestA
	+	{ hi && not how} How are you?
		~ how = true
		Popsy: Fine. Thanks!
		Popsy: How are you?
		+	+	I'm fine
				Player: Life is good.
				Popsy: Yes it is.
				-> TestA
		+	+	I would prefer to be dead.
				Player: Life sucks.
				Popsy: Not for me!
				Popsy: I'm a babyyyyyy.
				-> TestA
		+	+	What do you care?
				Player: Who cares?
				Popsy: I do.
				Popsy: You're my bigger brother.
				Player: oooowwwww.
				-> TestA
	+	{ how } How are you?
		Popsy: ...
		Popsy: You already asked that...
		-> TestA
	+	Bye!
		-> DONE


=== TestB ==
Player: I'm another sample ink story!
-> DONE
