using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using DevExpress.XtraReports.UI;

namespace iRely.Manufacturing.WebAPI.Reporting
{
    public partial class InventoryShipment : DevExpress.XtraReports.UI.XtraReport
    {
        public InventoryShipment()
        {
            InitializeComponent();
        }

        private void xrTableCell3_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
        {
            XRLabel itemCell = (XRLabel)sender;
            string item = GetCurrentColumnValue<string>("Item");
            string subLocation = GetCurrentColumnValue<string>("SubLocation");
            string storageLocation = GetCurrentColumnValue<string>("StorageLocation");

            if (!string.IsNullOrEmpty(subLocation) || !string.IsNullOrEmpty(storageLocation))
            {
                itemCell.Multiline = true;
                itemCell.Text = item + Environment.NewLine + subLocation + " / " + storageLocation;
            }
            else
            {
                itemCell.Multiline = false;
                itemCell.Text = item;
            }
        }

    }
}
