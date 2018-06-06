+const fsn = require("fs-nextra");
+module.exports = {
+	id: "order",
+	execute: (call) => {
+		const order = call.params.readRaw();
+		fsn.readJSON("./orders.json").then((orderDB) => {
+			function makeID() {
+				var id = "";
+				var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789";
+				for (var i = 0; i < 5; i++) id += possible.charAt(Math.floor(Math.random() * possible.length));
+				//eslint-disable-next-line newline-before-return
+				return id;
+			}
+			const orderID = makeID();
+
+			if (!orderDB[orderID]) orderDB[orderID] = {
+				"orderID": orderID,
+				"userID": call.message.author.id,
+				"guildID": call.message.guild.id,
+				"channelID": call.message.channel.id,
+				"order": order,
+				"status": "Waiting"
+			};
+
+			fsn.writeJSON("./orders.json", orderDB, { replacer: null, spaces: 2 }).then(() => {
+				call.message.reply(`Your order has been sent to the kitchen! Your order ID is \`${orderID}\``);
+				var ordersChan = call.client.channels.get("433831764105101332");
+				ordersChan.send("__**Order**__\n" +
+					`**OrderID:** ${orderID}\n` +
+					`**Order:** ${order}\n` +
+					`**Customer:** ${call.message.author.tag} (${call.message.author.id})\n` +
+					`**Ordered from:** #${call.message.channel.name} (${call.message.channel.id}) in ${call.message.guild.name} (${call.message.guild.id})\n` +
+					"**Status:** Awaiting a cook\n");
+			}).catch((err) => {
+				if (err) {
+					call.message.reply(`There was a database error! Show the following message to a developer: \`\`\`${err}\`\`\``);
+					console.error(`Error in order ${orderID} ${err}`);
+				}
+			});
+		});
+	}
+};
