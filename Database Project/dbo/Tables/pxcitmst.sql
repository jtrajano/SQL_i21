CREATE TABLE [dbo].[pxcitmst] (
    [pxcit_city_id]     CHAR (4)    NOT NULL,
    [pxcit_city_name]   CHAR (20)   NOT NULL,
    [pxcit_state]       CHAR (2)    NOT NULL,
    [pxcit_user_id]     CHAR (16)   NULL,
    [pxcit_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_pxcitmst] PRIMARY KEY NONCLUSTERED ([pxcit_city_id] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ipxcitmst0]
    ON [dbo].[pxcitmst]([pxcit_city_id] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Ipxcitmst1]
    ON [dbo].[pxcitmst]([pxcit_city_name] ASC, [pxcit_state] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[pxcitmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[pxcitmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[pxcitmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[pxcitmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[pxcitmst] TO PUBLIC
    AS [dbo];

