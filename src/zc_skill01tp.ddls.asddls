@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for Skill'
@ObjectModel.semanticKey: [ 'SID' ]
@Search.searchable: true
@ObjectModel.usageType:{
    serviceQuality: #X, 
    sizeCategory: #S, 
    dataClass: #MIXED
}
define view entity ZC_Skill01TP
  as projection on ZR_Skill01TP as Skill
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key EID,
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90 
  key SID,
  Sname,
  Exp,
  Hotskill,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt,
  _SkillHist : redirected to composition child ZC_SkillHistTP,
  _Emp : redirected to parent ZC_Emp02TP
  
}
