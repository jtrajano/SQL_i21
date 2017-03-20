CREATE FUNCTION [dbo].[fnSMConcatRecipients]
(
  @activityId INT
)
RETURNS NVARCHAR(MAX)
WITH SCHEMABINDING 
AS 
BEGIN
  DECLARE @s NVARCHAR(MAX);
 
  SELECT @s = COALESCE(@s + N', ', N'') + 
  ISNULL(Entity.strName, Recipient.strEmailAddress)
    FROM dbo.tblSMActivity Activity
	INNER JOIN dbo.tblSMEmailRecipient Recipient on Activity.intActivityId = Recipient.intEmailId
	LEFT JOIN dbo.tblEMEntity Entity on Recipient.intEntityContactId = Entity.intEntityId
	WHERE intActivityId = @activityId
 
  RETURN (@s);
END
GO