CREATE VIEW [dbo].[vyuHDCoworkerSuperVisor]
AS
SELECT   [intCoworkerSuperVisorId]			= CoworkerSuperVisor.[intCoworkerSuperVisorId]			
		,[intEntityId]						= CoworkerSuperVisor.[intEntityId]	
		,[ysnAutoAdded]						= CoworkerSuperVisor.[ysnAutoAdded]
		,[intConcurrencyId] 				= CoworkerSuperVisor.[intConcurrencyId]
		,[strFullName]						= Entity.[strName]
FROM tblHDCoworkerSuperVisor CoworkerSuperVisor
		INNER JOIN tblEMEntity Entity
ON Entity.intEntityId = CoworkerSuperVisor.intEntityId


GO