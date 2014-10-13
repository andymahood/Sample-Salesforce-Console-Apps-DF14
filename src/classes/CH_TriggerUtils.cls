public with sharing class CH_TriggerUtils {

  /**
   *  Filters list of SObjects based on whether the value of a particular field has changed
   *  <p>Note: this returns the objects in the 'new' list that have changed the values
   *  @param newList List<SObject>
   *  @param oldMap (Map<id<SObject>)
   *  @param fieldName (String) the field to check for differences on
   *  @param resultList (List<SObject>) - the list to put the 'new' objects that have changed
   **/
  public static void filterChangedObjects( List<SObject> newList, Map<Id,SObject> oldMap, String fieldName, List<SObject> resultList ){
    if( resultList == null ) return;
    resultList.clear();
    
    //-- if oldMap is null, then all items must be new
    if( oldMap == null ){
      resultList.addAll( newList );
      return;
    }
    
    SObject old;
    for( SObject obj : newList ){
      if( obj.id != null ){
        if( oldMap.containsKey( obj.id )){
          old = oldMap.get( obj.id );
          System.debug( 'old[' + fieldName + ']:' + old.get(fieldName) + ', ob[]:' + obj.get(fieldName) );
          if( old.get( fieldName ) != obj.get(fieldName ) ){
            resultList.add( obj );
          }
        } else {
          resultList.add( obj );
        }
      } else {
        resultList.add( obj );
      }
    }
  }
  
  /**
   *  Filters list of SObjects based on whether the value of a particular field has NOT changed
   *  <p>Note: this returns the objects in the 'new' list that have NOT changed the values
   *  @param newList List<SObject>
   *  @param oldMap (Map<id<SObject>)
   *  @param fieldName (String) the field to check for differences on
   *  @param resultList (List<SObject>) - the list to put the 'new' objects that have changed
   **/
  public static void filterNotChangedObjects( List<SObject> newList, Map<Id,SObject> oldMap, String fieldName, List<SObject> resultList ){
    if( resultList == null ) return;
    resultList.clear();
    
    //-- if oldMap is null, then all items must be new 
    if( oldMap == null ){
      resultList.addAll( newList );
      return;
    }
    
    SObject old;
    for( SObject obj : newList ){
      if( obj.id != null ){
        if( oldMap.containsKey( obj.id )){
          old = oldMap.get( obj.id );
          //System.debug( 'old[' + fieldName + ']:' + old.get(fieldName) + ', ob[]:' + obj.get(fieldName) );
          if( old.get( fieldName ) == obj.get(fieldName ) ){
            resultList.add( obj );
          }
        } else {
          resultList.add( obj );
        }
      } else {
        resultList.add( obj );
      }
    }
  }
}