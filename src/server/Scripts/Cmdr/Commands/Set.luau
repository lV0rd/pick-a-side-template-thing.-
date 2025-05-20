return {
	Name = "Set";
	Aliases = {"set", "make", "turn", "s"};
	Description = "Set a specified amount to selected stat of a player.";
	Group = "Admin";
	Args = {
		{
			Type = "string";
			Name = "Stat";
			Description = "Stat you want to add to";
		},
		{
			Type = "number";
			Name = "Amount";
			Description = "Amount you want to add"
		},
        {
            Type = "player";
            Name = "Player";
            Description = "Selected player",
            Optional = true
        }
	};
}