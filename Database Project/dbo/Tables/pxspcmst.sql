CREATE TABLE [dbo].[pxspcmst] (
    [pxspc_state_id]       CHAR (2)    NOT NULL,
    [pxspc_fuel_code]      CHAR (3)    NOT NULL,
    [pxspc_fuel_code_desc] CHAR (40)   NULL,
    [pxspc_user_id]        CHAR (16)   NULL,
    [pxspc_user_rev_dt]    INT         NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ipxspcmst0]
    ON [dbo].[pxspcmst]([pxspc_state_id] ASC, [pxspc_fuel_code] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[pxspcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[pxspcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[pxspcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[pxspcmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[pxspcmst] TO PUBLIC
    AS [dbo];

