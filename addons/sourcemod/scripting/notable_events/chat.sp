#define CHAT_TAG "[Notable Event]"

stock void ChatPrintToChat(int client, const char[] message, any ...)
{
	int len = strlen(message) + 255;
	char[] buffer = new char[len];
	VFormat(buffer, len, message, 3);
	
	switch(client)
	{
	    case 0: PrintToConsole(client, buffer);
	    default: SendMessage(client, buffer, len);
	}
}


stock void ChatPrintToChatAll(const char[] message, any ...)
{
	int len = strlen(message) + 255;
	char[] buffer = new char[len];
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			VFormat(buffer, len, message, 2);
			SendMessage(i, buffer, len);
		}
	}
}


stock void SendMessage(int client, char[] buffer, int size)
{
	Format(buffer, size, "\x01%s %s", CHAT_TAG, buffer);
	ReplaceString(buffer, size, "{C}", "\x07");
	
	Handle msg = StartMessageOne("SayText2", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
	BfWrite bf = UserMessageToBfWrite(msg);
	bf.WriteByte(client);
	bf.WriteByte(true);
	bf.WriteString(buffer);
	EndMessage();
}