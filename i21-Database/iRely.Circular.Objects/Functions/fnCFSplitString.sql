CREATE FUNCTION [dbo].[fnCFSplitString] 
    (   
    @DelimitedString    varchar(max),
    @Delimiter              varchar(100) 
    )
RETURNS @tblArray TABLE
    (
    RecordKey   int IDENTITY(1,1),  -- Array index
    Record     varchar(1000)               -- Array element contents
    )
AS
BEGIN
	/*
		RecordKey is being used by a view in Entity [ vyuEMETExportCustomerComment ]
		Any changes on this return table please inform the Entity Developer
		Thanks 2017.01.12
	*/
    -- Local Variable Declarations
    -- ---------------------------
    DECLARE @Index      smallint,
                    @Start      smallint,
                    @DelSize    smallint

    SET @DelSize = LEN(@Delimiter)

    -- Loop through source string and add elements to destination table array
    -- ----------------------------------------------------------------------
    WHILE LEN(@DelimitedString) > 0
    BEGIN

        SET @Index = CHARINDEX(@Delimiter, @DelimitedString)

        IF @Index = 0
            BEGIN

                INSERT INTO
                    @tblArray 
                    (Record)
                VALUES
                    (LTRIM(RTRIM(@DelimitedString)))

                BREAK
            END
        ELSE
            BEGIN

                INSERT INTO
                    @tblArray 
                    (Record)
                VALUES
                    (LTRIM(RTRIM(SUBSTRING(@DelimitedString, 1,@Index - 1))))

                SET @Start = @Index + @DelSize
                SET @DelimitedString = SUBSTRING(@DelimitedString, @Start , LEN(@DelimitedString) - @Start + 1)

            END
    END

    RETURN
END