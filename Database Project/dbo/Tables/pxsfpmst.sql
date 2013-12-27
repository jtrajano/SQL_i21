CREATE TABLE [dbo].[pxsfpmst] (
    [pxsfp_state_id]       CHAR (2)    NOT NULL,
    [pxsfp_form_id]        CHAR (8)    NOT NULL,
    [pxsfp_sched_id]       CHAR (6)    NOT NULL,
    [pxsfp_fuel_code]      CHAR (3)    NOT NULL,
    [pxsfp_fuel_code_desc] CHAR (40)   NULL,
    [pxsfp_user_id]        CHAR (16)   NULL,
    [pxsfp_user_rev_dt]    INT         NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ipxsfpmst0]
    ON [dbo].[pxsfpmst]([pxsfp_state_id] ASC, [pxsfp_form_id] ASC, [pxsfp_sched_id] ASC, [pxsfp_fuel_code] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[pxsfpmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[pxsfpmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[pxsfpmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[pxsfpmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[pxsfpmst] TO PUBLIC
    AS [dbo];

