CREATE FUNCTION fnGLGetOverrideAccountByAccount
(
    @intAccountId INT, -- used to override
    @intAccountId1 INT,
    @ysnOverrideLocation BIT =1,
    @ysnOverrideLOB BIT = 1,
    @ysnOverrideCompany BIT = 1
    
)  -- will be overriden      
RETURNS NVARCHAR(40)
AS
BEGIN
    DECLARE 
    @strAccountId NVARCHAR(40), -- used to override
    @strAccountId1 NVARCHAR(40) ,
    @intStructureType INT

    SELECT @strAccountId = strAccountId FROM tblGLAccount WHERE intAccountId = @intAccountId
    SELECT @strAccountId1 = strAccountId FROM tblGLAccount WHERE intAccountId = @intAccountId1


    WHILE  @ysnOverrideCompany = 1 OR @ysnOverrideLOB = 1 OR @ysnOverrideLocation = 1
    BEGIN

        DECLARE @intStart INT, @intEnd INT, @intLength INT, @intDividerCount INT,  @strSegment NVARCHAR(10) 

        IF @ysnOverrideLocation =1 
		BEGIN
           SET @intStructureType = 3
		   SET @ysnOverrideLocation = 0
		END
		ELSE
        
        IF @ysnOverrideLOB =1 
		BEGIN
           SET @intStructureType = 5
		   SET  @ysnOverrideLOB = 0
		END
		ELSE

        IF @ysnOverrideCompany =1 
          	BEGIN
           SET @intStructureType = 6
		   SET  @ysnOverrideCompany = 0
		END

        IF EXISTS(SELECT 1 FROM tblGLAccountStructure WHERE intStructureType =@intStructureType)
        BEGIN

            SELECT @intDividerCount = COUNT(1)  FROM tblGLAccountStructure WHERE strType <> 'Divider' and intStructureType < @intStructureType

            SELECT @intStart = SUM(intLength) + @intDividerCount FROM tblGLAccountStructure WHERE strType <> 'Divider' and intStructureType < @intStructureType -- location
            SELECT @intLength = intLength FROM tblGLAccountStructure WHERE intStructureType = @intStructureType -- lob
            SELECT @intEnd = @intStart + @intLength

            
            SELECT @strSegment = SUBSTRING(@strAccountId,@intStart+1,@intLength)
            declare @intL int = len(@strAccountId)
            declare @str NVARCHAR(30)=''
            DECLARE @i int = 1
            WHILE @i <= @intL
            BEGIN
                if @i > @intStart and @i < @intEnd
                BEGIN
                    SELECT @str+= @strSegment
                    SET @i = @i + @intLength
                END
                ELSE
                BEGIN
                    SELECT @str+= SUBSTRING(@strAccountId1, @i, 1)
                    SET @i=@i+1
                END
            
            END 
        END

        SET @strAccountId1 = @str

	END
    
    RETURN @str
END
