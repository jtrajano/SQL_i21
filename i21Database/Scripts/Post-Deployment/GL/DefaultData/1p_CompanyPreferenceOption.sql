
GO
IF EXISTS (SELECT TOP 1 1 FROM tblGLCompanyPreferenceOption)
    UPDATE tblGLCompanyPreferenceOption SET intDBVersion = CAST( SUBSTRING( @@version, 22,4) as int)
ELSE 
    INSERT INTO tblGLCompanyPreferenceOption (intConcurrencyId, intDBVersion) SELECT 1, CAST( SUBSTRING( @@version, 22,4) as int)
GO

-- update what segment to override in retained earnings during closing period.
IF EXISTS(SELECT 1 FROM tblGLCompanyPreferenceOption WHERE ISNULL(ysnREOverride,0) =1)
BEGIN
    
        DECLARE @ysnREOverrideLocation BIT,
                @ysnREOverrideLOB      BIT,
                @ysnREOverrideCompany  BIT

        SELECT TOP 1 @ysnREOverrideLocation = ysnREOverrideLocation,
                    @ysnREOverrideLOB = ysnREOverrideLOB,
                    @ysnREOverrideCompany = ysnREOverrideCompany
        FROM   tblGLCompanyPreferenceOption

        DECLARE @tbl TABLE
        (
            rowId            INT,
            intStructureType INT
        )

        INSERT INTO @tbl
        SELECT ROW_NUMBER() OVER (ORDER BY intSort ASC) AS rowId, intStructureType
        FROM   tblGLAccountStructure
        WHERE  strType != 'Divider'

        DECLARE @i          INT,
                @intSType   INT,
                @str        NVARCHAR(10)='',
                @ysnStarted BIT = 0

        WHILE EXISTS(SELECT 1 FROM   @tbl)
        BEGIN
            IF @ysnStarted = 1
                SET @str += ','

            SELECT TOP 1 @i = rowId - 1,
                        @intSType = intStructureType
            FROM   @tbl

            IF ( ISNULL(@ysnREOverrideLocation, 0) = 1
                AND @intSType = 3 )
                BEGIN
                    SET @str += Cast(@i AS NVARCHAR(1))
                    SET @ysnStarted = 1
                END

            IF ( ISNULL(@ysnREOverrideLOB, 0) = 1
                AND @intSType = 5 )
                BEGIN
                    SET @str += Cast(@i AS NVARCHAR(1))
                    SET @ysnStarted = 1
                END

            IF ( ISNULL(@ysnREOverrideCompany, 0) = 1
                AND @intSType = 6 )
                BEGIN
                    SET @str += Cast(@i AS NVARCHAR(1))
                    SET @ysnStarted = 1
                END

            DELETE FROM @tbl WHERE  rowId = @i
        END

        UPDATE tblGLCompanyPreferenceOption set strOverrideREArray = @str 

END
GO