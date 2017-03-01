/*
## Overview
tblICItemSubLocation
This table maps the sub-locations that can be assigned to an item. 
If no records is specified for an item, this means the item can be used in any sub-location. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.
	
	
## Source Code:
*/
CREATE TABLE tblICItemSubLocation (
	intItemSubLocationId INT NOT NULL IDENTITY,
	[intItemLocationId] INT NOT NULL,
	intSubLocationId INT NOT NULL ,
	[intConcurrencyId] INT NULL DEFAULT ((0)), 
	CONSTRAINT [PK_tblICItemSubLocation] PRIMARY KEY ([intItemSubLocationId]), 
	CONSTRAINT [FK_tblICItemSubLocation_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation] ([intItemLocationId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblICItemSubLocation_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
)
GO

CREATE UNIQUE INDEX [IX_tblICItemSubLocation_intItemLocationId_intSubLocationId]
	ON [dbo].[tblICItemSubLocation]([intItemLocationId] ASC, [intSubLocationId] ASC);
GO