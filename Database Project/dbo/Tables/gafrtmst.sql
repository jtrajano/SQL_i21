CREATE TABLE [dbo].[gafrtmst] (
    [gafrt_origin]     CHAR (20)       NOT NULL,
    [gafrt_dest]       CHAR (20)       NOT NULL,
    [gafrt_per_ton_rt] DECIMAL (9, 5)  NULL,
    [gafrt_per_car_rt] DECIMAL (11, 5) NULL,
    [A4GLIdentity]     NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gafrtmst] PRIMARY KEY NONCLUSTERED ([gafrt_origin] ASC, [gafrt_dest] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Igafrtmst0]
    ON [dbo].[gafrtmst]([gafrt_origin] ASC, [gafrt_dest] ASC);


GO
CREATE NONCLUSTERED INDEX [Igafrtmst1]
    ON [dbo].[gafrtmst]([gafrt_dest] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gafrtmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gafrtmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gafrtmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gafrtmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[gafrtmst] TO PUBLIC
    AS [dbo];

