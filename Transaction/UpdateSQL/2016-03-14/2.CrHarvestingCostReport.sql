
/****** Object:  StoredProcedure [Checkroll].[CRAnalysisHarvestingCostReport]    Script Date: 11/3/2016 11:48:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Created By		: Palani
-- Created Date		: 22-June-2011
-- Modified By		: Palani
-- Modified Date	: 22-June-2011
-- Descp			: Analysis Harvesting Cost Report SP

CREATE PROCEDURE [Checkroll].[CRAnalysisRubberCostReport]
	@EstateID nvarchar(50),
	@ActiveMonthYearID nvarchar(50)
AS
BEGIN

select MainDescription,SubDescription,YOP,MainOrderCounter,SubOrderCounterMain,
SubOrderCounterSub,PayrollBunches,FactoryKG,KGPerBunches,Mandays,KGPerMandays,Cost,CostPerKG,CostPerBunches,
FactoryBunches,DifferenceBunches,b.PlantedHect from Checkroll.AnalyLatexCost
inner join (
select SUm(PlantedHect) as PlantedHect, b.Name from General.BlockMaster a
inner join general.YOP b on a.YOPID = b.YOPID where CropID = 'M2'
group by b.Name) b on  Checkroll.AnalyLatexCost.YOP = b.Name
where EstateID = @EstateID and ActiveMonthYearID =@ActiveMonthYearID

END

