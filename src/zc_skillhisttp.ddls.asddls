@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forSkillHist'
@ObjectModel.semanticKey: [ 'ShID' ]
@Search.searchable: true
@ObjectModel.usageType:{
    serviceQuality: #X, 
    sizeCategory: #S, 
    dataClass: #MIXED
}
define view entity ZC_SkillHistTP
  as projection on ZR_SkillHistTP as SkillHist
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key SID,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key ShID,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key EID,
  Projname,
  Projyear,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt,
  _Skill : redirected to parent ZC_Skill01TP,
  _Emp : redirected to ZC_Emp02TP
  
}
