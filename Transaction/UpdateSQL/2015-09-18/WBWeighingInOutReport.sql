
/****** Object:  StoredProcedure [Weighbridge].[WBWeighingInOutReport]    Script Date: 18/9/2015 6:18:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [Weighbridge].[WBWeighingInOutReport]
	
	-- Add the parameters for the stored procedure here
	@EstateID nvarchar(50),
	@WBTicketNo nvarchar(50),
	@ActiveMonthYearID nvarchar(50),
	@Others Char(1)
 

	
AS   
	SET NOCOUNT ON;
	
BEGIN

		SELECT	WBWeighingInOut.FFBDeliveryOrderNo, 
				CONVERT(VARCHAR(10), WBWeighingInOut.WeighingDate, 103) AS WeighingDate, 
				--WBWeighingInOut.WeighingTime, 
				CONVERT(VARCHAR(5),  WBWeighingInOut.WeighingTime, 108) 	 as WeighingTime,
				WBWeighingInOut.Section,
				WBWeighingInOut.WBTicketNo,  
				--WBWeighingInOut.TimeOut,
				CONVERT(VARCHAR(5),  WBWeighingInOut.TimeOut, 108) 	 as TimeOut,
				WBWeighingInOut.DriverName,  WBWeighingInOut.NoTrip, 
				FLOOR(WBWeighingInOut.FirstWeight) As FirstWeight,
				FLOOR(WBWeighingInOut.SecondWeight) As SecondWeight,
				FLOOR(WBWeighingInOut.NetWeight) As NetWeight,
				WBWeighingInOut.ManualWeight, 
				WBWeighingInOut.Remarks, WBWeighingInOut.CreatedBy,
				WBVehicle.VHNo AS VehicleCode, WBProductMaster.ProductCode,WBSupplier.Name AS Supplier,
				WBFieldBlockSetup.Div, WBFieldBlockSetup.YOP, WBFieldBlockSetup.Block, WBWeighingBlockDetail.Qty, Estate.EstateName,WBProductMaster.ProductDescp 
		FROM	Weighbridge.WBWeighingInOut	
				LEFT JOIN Weighbridge.WBVehicle ON WBVehicle.WBVehicleID = WBWeighingInOut.WBVehicleID 
				LEFT JOIN Weighbridge.WBProductMaster ON WBWeighingInOut.ProductID = WBProductMaster.ProductID 
				LEFT JOIN Weighbridge.WBSupplier ON WBWeighingInOut.SupplierCustID = WBSupplier.SupplierCustID 
				LEFT JOIN Weighbridge.WBWeighingBlockDetail ON WBWeighingInOut.WeighingID = WBWeighingBlockDetail.WeighingID
				LEFT JOIN Weighbridge.WBFieldBlockSetup ON WBWeighingBlockDetail.FieldBlockSetupID  = WBFieldBlockSetup.FieldBlockSetupID 
				INNER JOIN General.Estate ON WBWeighingInOut.EstateID = Estate.EstateID 
		WHERE	WBWeighingInOut.EstateID = @EstateID AND WBWeighingInOut.ActiveMonthYearID = @ActiveMonthYearID AND
				WBWeighingInOut.WBTicketNo = @WBTicketNo 
				--AND WBWeighingInOut.Others = @Others
		
	END
	
	
	
 













