CREATE FUNCTION [{{schema}}].[encode1]
(
	@number int
)
RETURNS nvarchar(255)
WITH SCHEMABINDING
AS
BEGIN
	-- Options Data - generated by hashids-tsql
	DECLARE
		@salt nvarchar(255) = N'{{salt}}',
		@alphabet nvarchar(255) = N'{{alphabet}}',
		@seps nvarchar(255) = N'{{seps}}',
		@guards nvarchar(255) = N'{{guards}}',
		@minHashLength int = {{minHashLength}};
		-- Input Alphabet: N'{{inputAlphabet}}'

	-- Working Data
	DECLARE
		@numbersHashInt int,
		@lottery nchar(1),
		@buffer nvarchar(255),
		@last nvarchar(255),
		@ret nvarchar(255);

	SET @numbersHashInt = @number % 100;
	SET @lottery = SUBSTRING(@alphabet, (@numbersHashInt % LEN(@alphabet)) + 1, 1);
	SET @ret = @lottery;
	SET @buffer = @lottery + @salt + @alphabet;
	SET @alphabet = [{{schema}}].[consistentShuffle](@alphabet, SUBSTRING(@buffer, 1, LEN(@alphabet)));
	SET @last = [{{schema}}].[hash](@number, @alphabet);
	SET @ret = @ret + @last;
	----------------------------------------------------------------------------
	-- Enforce minHashLength
	----------------------------------------------------------------------------
	IF LEN(@ret) < @minHashLength BEGIN
		DECLARE
			@guardIndex int,
			@guard nchar(1),
			@halfLength int,
			@excess int;
		------------------------------------------------------------------------
		-- Add first 2 guard characters
		------------------------------------------------------------------------
		SET @guardIndex = (@numbersHashInt + UNICODE(SUBSTRING(@ret, 1, 1))) % LEN(@guards);
		SET @guard = SUBSTRING(@guards, @guardIndex + 1, 1);
		SET @ret = @guard + @ret;
		IF LEN(@ret) < @minHashLength BEGIN
			SET @guardIndex = (@numbersHashInt + UNICODE(SUBSTRING(@ret, 3, 1))) % LEN(@guards);
			SET @guard = SUBSTRING(@guards, @guardIndex + 1, 1);
			SET @ret = @ret + @guard;
		END
		------------------------------------------------------------------------
		-- Add the rest
		------------------------------------------------------------------------
		WHILE LEN(@ret) < @minHashLength BEGIN
			SET @halfLength = IsNull(@halfLength, CAST((LEN(@alphabet) / 2) as int));
			SET @alphabet = [{{schema}}].[consistentShuffle](@alphabet, @alphabet);
			SET @ret = SUBSTRING(@alphabet, @halfLength + 1, 255) + @ret + 
					SUBSTRING(@alphabet, 1, @halfLength);
			SET @excess = LEN(@ret) - @minHashLength;
			IF @excess > 0 
				SET @ret = SUBSTRING(@ret, CAST((@excess / 2) as int) + 1, @minHashLength);
		END
	END
	RETURN @ret;
END