
/****** Object:  StoredProcedure [Weighbridge].[WBWeighingTicketReport]    Script Date: 18/9/2015 6:08:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [Weighbridge].[WBWeighingTicketReport]
	
	-- Add the parameters for the stored procedure here
	@EstateID nvarchar(50),
	@ActiveMonthYearID nvarchar(50)
	
 

	
AS   
	SET NOCOUNT ON;
	
BEGIN

		SELECT	WBWeighingInOut.WBTicketNo
		FROM	Weighbridge.WBWeighingInOut	
				INNER JOIN General.Estate ON WBWeighingInOut.EstateID = Estate.EstateID 
		WHERE	WBWeighingInOut.EstateID = @EstateID AND WBWeighingInOut.ActiveMonthYearID = @ActiveMonthYearID AND
				WBWeighingInOut.SecondWeight  <> 0
		
	END
	


