int SignInt(int i)
{
	int result;

	if (i > 0) result = 1;
	else if (i < 0) result = -1;
	else result = 0;

	return result;
}