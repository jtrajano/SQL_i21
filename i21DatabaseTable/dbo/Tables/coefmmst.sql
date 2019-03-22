CREATE TABLE [dbo].[coefmmst] (
    [coefm_pgm_id]             CHAR (12)      NOT NULL,
    [coefm_loc_no]             CHAR (3)       NOT NULL,
    [coefm_form_type]          CHAR (3)       NULL,
    [coefm_page_width]         DECIMAL (4, 2) NULL,
    [coefm_page_height]        DECIMAL (4, 2) NULL,
    [coefm_text_top_margin]    DECIMAL (3, 2) NULL,
    [coefm_text_left_margin]   DECIMAL (3, 2) NULL,
    [coefm_font_no]            TINYINT        NULL,
    [coefm_point_size]         TINYINT        NULL,
    [coefm_comp_factor]        SMALLINT       NULL,
    [coefm_vert_space]         TINYINT        NULL,
    [coefm_image_filename]     CHAR (64)      NULL,
    [coefm_hor_margin]         DECIMAL (3, 2) NULL,
    [coefm_vert_margin]        DECIMAL (3, 2) NULL,
    [coefm_days_retention]     SMALLINT       NULL,
    [coefm_postnet_enabled_yn] CHAR (1)       NULL,
    [coefm_postnet_position_x] DECIMAL (4, 2) NULL,
    [coefm_postnet_position_y] DECIMAL (4, 2) NULL,
    [coefm_esig_enabled_yn]    CHAR (1)       NULL,
    [coefm_esig_pos_x]         DECIMAL (4, 2) NULL,
    [coefm_esig_pos_y]         DECIMAL (4, 2) NULL,
    [coefm_esig_width]         DECIMAL (3, 2) NULL,
    [coefm_esig_height]        DECIMAL (3, 2) NULL,
    [coefm_text_top_margin2]   DECIMAL (3, 2) NULL,
    [coefm_text_left_margin2]  DECIMAL (3, 2) NULL,
    [coefm_font_no2]           TINYINT        NULL,
    [coefm_point_size2]        TINYINT        NULL,
    [coefm_comp_factor2]       SMALLINT       NULL,
    [coefm_vert_space2]        TINYINT        NULL,
    [coefm_active_yn]          CHAR (1)       NULL,
    [coefm_firstpage_yn]       CHAR (1)       NULL,
    [coefm_image_width]        DECIMAL (4, 2) NULL,
    [coefm_image_height]       DECIMAL (4, 2) NULL,
    [coefm_addendum_filename]  CHAR (64)      NULL,
    [coefm_addendum_yn]        CHAR (1)       NULL,
    [A4GLIdentity]             NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_coefmmst] PRIMARY KEY NONCLUSTERED ([coefm_pgm_id] ASC, [coefm_loc_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icoefmmst0]
    ON [dbo].[coefmmst]([coefm_pgm_id] ASC, [coefm_loc_no] ASC);

