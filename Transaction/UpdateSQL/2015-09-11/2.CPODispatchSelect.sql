/****** Object:  StoredProcedure [Production].[CPODispatchSelect]    Script Date: 11/9/2015 9:47:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Production].[CPODispatchSelect] 

	-- Add the parameters for the stored procedure here
	
	@EstateID nvarchar(50),
	@ProductID nvarchar(50),
	@DispatchDate Date,
	@ActiveMonthYearID nvarchar(50)

	
	AS   
			BEGIN
			Select
			P_DISP.DispatchID , 
			P_DISP.DispatchDate,
			P_DISP.BAPNo,
			P_DISP.ShipPontoon,
			P_DISP.DOA,
			P_DISP.DOATime,
			P_DISP.DOL,
			P_DISP.DOLTime,
			P_DISP.DCL,
			P_DISP.DCLTime,
			P_DISP.DepartureDate,
			P_DISP.DepartureTime,
			P_DISP.MillWeight,
			P_DISP.BuyerName, 
			P_DISP.KontrakNo,
			P_DISP.NoPenyerahan,
			P_DISP.NoInstruksi,
			P_DISP.JumlahKontrak,
			P_DISP.NoSim ,
			P_DISP.NoTruk,
			P_DISP.SealNo,
			P_DISP.DriverName ,
			P_DISP.TransporterNo ,
			P_DISP.SPBNo,
			P_DISP.TermofSales,
			P_LL.LoadingLocationCode as LoadingLocation,
			(Select ProductDescp    from Weighbridge .WBProductMaster where ProductID =@ProductID)as Type 
				from Production .CPODispatch as P_DISP
			Left Join Production .LoadingLocation as P_LL ON P_LL .LoadingLocationID = P_DISP.LoadingLocationID 
			Inner Join Weighbridge .WBProductMaster as W_PM ON W_PM .ProductID = P_DISP .ProductID 
			where 
			P_DISP.EstateID = @EstateID  
			AND P_DISP.ProductID =@ProductID 
			AND (case when @DispatchDate = '01/01/1900' then 1  end =1 or P_DISP.DispatchDate   =@DispatchDate ) 
			AND P_DISP .ActiveMonthYearID =@ActiveMonthYearID 
			order by P_DISP.Id desc	 			
			
			END






















