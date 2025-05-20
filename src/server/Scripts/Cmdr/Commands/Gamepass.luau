return {
	Name = "Gamepass";
	Aliases = {"pass", "gamepass", "gp", "p"};
	Description = "Give gamepass to play.";
	Group = "Admin";
	Args = {
		{
			Type = "number";
			Name = "ID";
			Description = "Gamepass Id";
		},
        {
            Type = "player";
            Name = "Player";
            Description = "Selected player",
            Optional = true
        }
	};
}