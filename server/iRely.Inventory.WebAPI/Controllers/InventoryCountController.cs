﻿using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;

namespace iRely.Inventory.WebApi
{
    public class InventoryCountController : BaseApiController<tblICInventoryCount>
    {
        private IInventoryCountBl _bl;

        public InventoryCountController(IInventoryCountBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        public async Task<HttpResponseMessage> GetCountSheets(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetCountSheets(param));
        }

        [HttpPost]
        [ActionName("LockInventory")]
        public HttpResponseMessage LockInventory(int inventoryCountId)
        {
            var result = _bl.LockInventory(inventoryCountId);

            return Request.CreateResponse(HttpStatusCode.Accepted, new
            {
                data = inventoryCountId,
                success = !result.HasError,
                message = new
                {
                    statusText = result.Exception.Message,
                    status = result.Exception.Error,
                    button = result.Exception.Button.ToString()
                }
            });
        }

    }
}
