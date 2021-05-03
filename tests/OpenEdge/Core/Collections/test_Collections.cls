USING OpenEdge.Core.Assert FROM PROPATH.
USING OpenEdge.Core.Collections.* FROM PROPATH.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS OpenEdge.Core.Collections.test_Collections: 
  @Test.
  METHOD VOID TestStringStringMap(): 
    DEFINE VARIABLE configurationDictionary AS IStringStringMap NO-UNDO.
    
    configurationDictionary = NEW StringStringMap().
    Assert:NotNull(configurationDictionary).

  END METHOD.

  @Test.
  METHOD VOID TestPutToStringStringMap(): 
    DEFINE VARIABLE configurationDictionary AS IStringStringMap NO-UNDO.
    
    configurationDictionary = NEW StringStringMap().
    Assert:NotNull(configurationDictionary).

    configurationDictionary:Put("Key1", "Value1").
    Assert:Equals(1, configurationDictionary:Size).

  END METHOD.

  @Test.
  METHOD VOID TestEntrySetFromStringStringMap(): 
    DEFINE VARIABLE configurationDictionary AS IStringStringMap NO-UNDO.
    
    configurationDictionary = NEW StringStringMap().
    Assert:NotNull(configurationDictionary).

    configurationDictionary:Put("Key1", "Value1").
    Assert:Equals(1, configurationDictionary:Size).

    DEFINE VARIABLE itemIterator AS IIterator NO-UNDO.
    itemIterator = configurationDictionary:EntrySet:Iterator(). 
    _CHILDREN:
    DO WHILE(itemIterator:HasNext()):
      DEFINE VARIABLE nextValueObject AS Progress.Lang.Object NO-UNDO.
      DEFINE VARIABLE nextValue AS IMapEntry NO-UNDO.

      nextValueObject = itemIterator:Next().
      Assert:NotNull(nextValueObject).
      
      Assert:IsType(nextValueObject, GET-CLASS("OpenEdge.Core.Collections.IMapEntry")).
      
      nextValue = CAST(nextValueObject, IMapEntry).
      Assert:IsType(nextValue, GET-CLASS("OpenEdge.Core.Collections.IMapEntry")).
      
      Assert:Equals("Key1", nextValue:Key:ToString()).
      Assert:Equals("Value1", nextValue:Value:ToString()).
    END.

  END METHOD.


END CLASS.