Create table tblIPItemSupplyTarget
(
intItemSupplyTarget int IDENTITY (1, 1) NOT NULL
,intItemId int
,dblSupplyTarget numeric(18,6)
,intBookId int
,intSubBookId int
,intCompanyId int
,CONSTRAINT PK_tblIPItemSupplyTarget PRIMARY KEY (intItemSupplyTarget)
,CONSTRAINT [FK_tblIPItemSupplyTarget_intBookId] FOREIGN KEY (intBookId) REFERENCES [tblCTBook](intBookId)
)