db.users.drop();
db.subscribers.drop();

db.users.save({
	email: "user@gmail.com", 
	password: "$2a$10$C0kXk9XgrSLdmeVjqSjYN.EoMnrUpkoig5C5Yl1BswkgWdO/og3wO",
	activated: true
});