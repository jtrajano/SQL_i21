CREATE TABLE [dbo].[tblCTBlendDemand]
(
[intBlendDemandId] INT NOT NULL IDENTITY (1, 1),
[intConcurrencyId] INT NOT NULL, 
[intItemId] INT NOT NULL,
[dtmDemandDate] DATETIME NOT NULL,
[dblQuantity] NUMERIC(18, 6) NOT NULL,
[intItemUOMId] INT NOT NULL,
intCompanyLocationId INT,

CONSTRAINT [PK_tblCTBlendDemand] PRIMARY KEY ([intBlendDemandId]), 
CONSTRAINT [FK_tblCTBlendDemand_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
CONSTRAINT [FK_tblCTBlendDemand_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
CONSTRAINT [FK_tblCTBlendDemand_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY (intCompanyLocationId) REFERENCES [tblSMCompanyLocation](intCompanyLocationId)
)
