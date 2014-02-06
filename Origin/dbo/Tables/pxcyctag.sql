CREATE TABLE [dbo].[pxcyctag] (
    [pxcyctag_cycle_id]         CHAR (6)    NOT NULL,
    [pxcyctag_cycle_seq]        SMALLINT    NOT NULL,
    [pxcyctag_beg_rev_dt]       INT         NULL,
    [pxcyctag_end_rev_dt]       CHAR (8)    NULL,
    [pxcyctag_i21_report_title] CHAR (100)  NULL,
    [pxcyctag_processed_yn]     CHAR (1)    NULL,
    [A4GLIdentity]              NUMERIC (9) IDENTITY (1, 1) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipxcyctag0]
    ON [dbo].[pxcyctag]([pxcyctag_cycle_id] ASC, [pxcyctag_cycle_seq] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[pxcyctag] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[pxcyctag] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[pxcyctag] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[pxcyctag] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[pxcyctag] TO PUBLIC
    AS [dbo];

