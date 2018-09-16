(*
    Recommender workflows grammar in EBNF
    Copyright (C) 2018  Anton Antonov

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

  	Written by Anton Antonov,
  	antononcube @@@ gmail ... com,
  	Windermere, Florida, USA.
*)

(* :Title: RecommenderWorkflowsGrammar *)
(* :Context: RecommenderWorkflowsGrammar` *)
(* :Author: Anton Antonov *)
(* :Date: 2018-09-16 *)

(* :Package Version: 0.1 *)
(* :Mathematica Version: 11.3 *)
(* :Copyright: (c) 2018 Anton Antonov *)
(* :Keywords: EBNF, recommender, grammar *)
(* :Discussion:

   # In brief

   The Extended Backus-Naur Form (EBNF) grammar in this file is intended to be used in a natural language commands
   interface for the creation recommenders and making recommendations using the monad SMRMon:

     https://github.com/antononcube/MathematicaForPrediction/blob/master/MonadicProgramming/MonadicSparseMatrixRecommender.m

   The grammar is partitioned into separate sub-grammars, each sub-grammar corresponding to a conceptual set of
   functionalities. (The intent is to facilitate understanding and further development.)


   # How to use

   This grammar is intended to be parsed by the functions in the Mathematica package FunctionalParses.m at GitHub,
   see https://github.com/antononcube/MathematicaForPrediction/blob/master/FunctionalParsers.m .

   (The file can be run in Mathematica with Get or Import.)


   # Example

   The following sequence of commands are parsed by the parsers generated with the grammar.

      Import["https://raw.githubusercontent.com/antononcube/ConversationalAgents/master/EBNF/RecommenderWorkflowsGrammar.m"]
      Import["https://raw.githubusercontent.com/antononcube/MathematicaForPrediction/master/FunctionalParsers.m"]


   ...


   # Implementation considerations

   - Currently the implementation symbols refer to SMRMon, but probably a more universal prefix should be used
     like "IIRMon".



   Anton Antonov
   2018-09-16
*)


If[Length[DownValues[FunctionalParsers`ParseToEBNFTokens]] == 0,
  Echo["FunctionalParsers.m", "Importing from GitHub:"];
  Import["https://raw.githubusercontent.com/antononcube/MathematicaForPrediction/master/FunctionalParsers.m"]
];

BeginPackage["RecommenderWorkflowsGrammar`"]

pSMRMONCOMMAND::usage = "Parses natural language commands for recommendations workflows."

SMRMonCommandsSubGrammars::usage = "Gives an association of the EBNF sub-grammars for parsing natural language commands \
specifying SMRMon pipelines construction."

SMRMonCommandsGrammar::usage = "Gives as a string an EBNF grammar for parsing natural language commands \
specifying SMRMon pipelines construction."

Begin["`Private`"]

Needs["FunctionalParsers`"]

(************************************************************)
(* Common parts                                             *)
(************************************************************)

ebnfCommonParts = "
  <list-delimiter> = 'and' | ',' | ',' , 'and' | 'together' , 'with' <@ ListDelimiter ;
  <with-preposition> =  'using' | 'by' | 'with' ;
  <using-preposition> = 'using' | 'with' | 'over' | 'for' ;
  <to-preposition> = 'to' | 'into' ;
  <by-preposition> = 'by' | 'through' | 'via' ;
  <number-value> = '_?NumberQ' <@ NumericValue ;
  <percent-value> = <number-value> <& ( '%' | 'percent' ) <@ PercentValue ;
  <boolean-value> = 'True' | 'False' | 'true' | 'false' <@ BooleanValue ;
  <display-directive> = 'show' | 'give' | 'display' <@ DisplayDirective ;
  <compute-directive> = 'compute' | 'calculate' | 'find' <@ ComputeDirective ;
  <compute-and-display> = <compute-directive> , [ 'and' &> <display-directive> ] <@ ComputeAndDisplay ;
  <generate-directive> = 'make' | 'create' | 'generate' <@ GenerateDirective ;
  <recommend-directive> = 'recommend' | 'suggest' <@ RecommendDirective ;
  <recommendation-matrix>  = [ 'recommendation' ] , 'matrix' <@ RecommendationMatrix ;
  <number-of> = ( 'number' | 'count' ) , 'of' <@ NumberOf ;
  <score-association-symbol> = '->' | ':' <@ ScoreAssociationSymbol ;
  <consumption-profile> = [ 'consumption' ] , 'profile' <@ ConsumptionProfile ;
  <consumption-history> = [ 'consumption' ] , 'history' <@ ConsumptionHistory ;
  <recommended-items> = 'recommended' , 'items' | ( 'recommendations' | 'recommendation' ) , [ 'results' ]  <@ RecommendedItems ;
  <recommender> = 'recommender' , [ 'object' | 'system' ] <@ Recommender ;
";


(************************************************************)
(* SMR create command                                       *)
(************************************************************)

ebnfCreateCommand = "
  <create-command> = <create-by-dataset> | <create-by-matrices> | <create-simple> <@ SMRCreateCommand ;
  <create-simple> = <generate-directive> <& [ [ 'the' ] , <recommender>  ] <@ SMRCreateSimple ;
  <create-by-dataset> = <create-simple> ,
                        ( <using-preposition> , [ 'the' ] , [ 'dataset' ] ) &> <smr-dataset-spec> ,
                        ( [ ( <with-preposition> , [ 'the' ] , [ 'id' , 'column' ] ) &> <id-column-spec> ] )
                        <@ SMRCreateByDataset ;
  <create-by-matrices> = ( <create-simple> <& <with-preposition> ) ,
                         ( [ 'the' ] , [ 'matrices' ] ) &> <smr-matrix-association-spec>
                         <@ SMRCreateByMatrices ;
  <smr-dataset-spec> = '_String' <@ SMRDatasetSpec ;
  <smr-matrix-association-spec> = '_String' <@ SMRMatrixAssociation ;
  <id-column-spec> = '_String' <@ SMRIDColumnSpec ;
";


(************************************************************)
(* SMR object properties queries                            *)
(************************************************************)

ebnfSMRQuery = "
  <smr-query-command> = <display-directive> , [ 'the' ] , <smr-property-spec> <@ SMRPropertyQuery ;
  <smr-property-spec> = <smr-context-property> | <smr-matrix-property> <@ SMRPropertySpec ;
  <smr-context-property> = 'tag' , 'types' | 'tags' | [ 'sparse' ] , 'matrices' | <recommendation-matrix> <@ SMRContextProperty@*Flatten@*List ;
  <smr-matrix-property> = <smr-matrix-columns> | <smr-matrix-rows> | <smr-matrix-dimensions> | <smr-matrix-density> <@ SMRMatrixProperty ;
  <smr-matrix-columns> = ( [ 'the' ] , [ <recommendation-matrix> ] , <number-of> ) &> 'columns' <@ SMRMatrixColumns ;
  <smr-matrix-rows> = ( [ 'the' ] , [ <recommendation-matrix> ] , <number-of> ) , 'rows' <@ SMRMatrixRows ;
  <smr-matrix-dimensions> = <recommendation-matrix> , 'dimensions' <@ SMRMatrixDimensions ;
  <smr-matrix-density> = <recommendation-matrix> , 'density' <@ SMRMatrixDensity ;
";


(************************************************************)
(* Recommendations                                          *)
(************************************************************)

ebnfRecommend = "
  <recommend-by-history-command> = <recommend-directive> , ( <using-preposition> | <by-preposition> ),
                                   [ [ 'the' ] , 'history' ] , <history-spec>
                                   <@ SMRRecommendByHistory ;
  <recommend-by-profile-command> = <recommend-directive> , ( <using-preposition> | <by-preposition> ) ,
                                   [ 'the' ] , <consumption-profile> , <profile-spec>
                                   <@ SMRRecommendByProfile ;
";

ebnfHistorySpec = "
  <history-spec> = <items-list> | <scored-items-list> ;
  <item> = '_String' <@ SMRItem ;
  <items-list> = <item> , [ { <list-delimiter> , <item> } ] <@ SMRItemsList ;
  <scored-item> = <item> , <score-association-symbol> &> <number-value> <@ SMRScoredItem ;
  <scored-items-list> = <scored-item> , [ { <list-delimiter> &> <scored-item> } ] <@ SMRScoredItemsList ;
  <scored-items-list> = <scored-item> , [ { <list-delimiter> &> <scored-item> } ] <@ SMRScoredItemsList ;
";

ebnfProfileSpec = "
  <profile-spec> = <items-list> | <scored-items-list> ;
";


(************************************************************)
(* Additional SMR commands                                  *)
(************************************************************)

ebnfMakeProfile = "
  <make-profile-command> = <compute-directive> , [ 'the' ] , <consumption-profile> , <using-preposition> , <item-history-spec> <@ SMRMakeProfile ;
";

ebnfProofs = "
  <proof-command> = <history-proof-command> | <profile-proof-command> | <explain-recommendations> <@ SMRProofCommand ;
  <explain-recommendations> = ( 'explain' , [ 'the' ] ) &> <recommended-items> <@ SMRExplainRecommendations ;
  <history-proof-command> = ( <explain-recommendations> , <with-preposition> , [ 'the' ] ) &> <consumption-history> <@ SMRHistoryProof ;
  <profile-proof-command> = ( <explain-recommendations> , <with-preposition> , [ 'the' ] ) &> <consumption-profile> <@ SMRProfileProof ;
";



(************************************************************)
(* General pipeline commands                                *)
(************************************************************)
(* This has to be refactored at some point since it is used in other workflow grammars. *)

ebnfPipelineCommand = "
  <pipeline-command> = <get-pipeline-value> | <get-pipeline-context> |
                       <pipeline-context-add> | <pipeline-context-retrieve> <@ PipelineCommand ;
  <pipeline-filler> = [ 'the' ] , [ 'current' ] , [ 'pipeline' ] ;
  <pipeline-value> = <pipeline-filler> &> 'value' <@ PipelineValue ;
  <get-pipeline-value> = <display-directive> &> <pipeline-value> <@ GetPipelineValue ;
  <pipeline-context> =  <pipeline-filler> &> 'context' <@ PipelineContext ;
  <pipeline-context-keys> =  <pipeline-filler> &> 'context' , 'keys' <@ PipelineContextKeys ;
  <context-key> = '_String' <@ ContextKey ;
  <pipeline-context-value> = ( <pipeline-filler> , 'context' , 'value' , ( 'for' | 'of' ) ) &> <context-key> |
                             ( ( 'value' , ( 'for' | 'of' ) , [ 'the' ] , 'context' , ( 'key' | 'element' | 'variable' ) ) &> <context-key>)
                             <@ PipelineContextValue ;
  <get-pipeline-context> = <display-directive> , ( <pipeline-context> | <pipeline-context-keys> | <pipeline-context-value> ) <@ GetPipelineContext ;
  <pipeline-context-add> = ( ( 'put' | 'add' ) , ( 'in' | 'into' | 'to' ) , 'context' , 'as' ) &> <context-key> <@ PipelineContextAdd ;
  <pipeline-context-retrieve> = ( 'get' | 'retrieve' ) &>
                                ( ( 'from' , 'context' ) &> <context-key> | <context-key> <& ( 'from' , 'context' ) )
                                <@ PipelineContextRetrieve ;
  ";


(************************************************************)
(* Second order commands                                    *)
(************************************************************)

ebnfGeneratePipeline = "
  <generate-pipeline> = <generate-pipeline-phrase> , [ <using-preposition> &> <classifier-algorithm> ] <@ GeneratePipeline ;
  <generate-pipeline-phrase> = <generate-directive> , [ 'an' | 'a' | 'the' ] , [ 'standard' ] , [ 'classification' ] , ( 'pipeline' | 'workflow' ) <@ Flatten ;
";

ebnfSecondOrderCommand = "
   <second-order-command> = <generate-pipeline>  <@ SecondOrderCommand ;
";


(************************************************************)
(* Combination                                              *)
(************************************************************)

(*ebnfCommand = "*)
  (*<smrmon-command> =*)
     (*<create-command> | <summarize-data> |*)
     (*<apply-term-weight-functions> |*)
     (*<apply-global-term-weight-function> | <apply-local-term-weight-function> | <apply-term-normalizer-function> |*)
     (*<recommend-by-history-command> | <recommend-by-profile-command> |*)
     (*<set-tag-type-weights> | <set-tags-weight> |*)
     (*<pipeline-command> | <second-order-command> ;*)
  (*";*)

ebnfCommand = "
  <smrmon-command> =
     <create-command> |
     <smr-query-command> |
     <recommend-by-history-command> | <recommend-by-profile-command> | <proof-command> |
     <make-profile-command> |
     <pipeline-command> | <second-order-command> ;
  ";

(************************************************************)
(* Generate parsers                                         *)
(************************************************************)

res =
    GenerateParsersFromEBNF[ParseToEBNFTokens[#]] & /@
        {ebnfCommand,
          ebnfCommonParts,
          ebnfCreateCommand, ebnfSMRQuery,
          ebnfRecommend, ebnfHistorySpec, ebnfProfileSpec,
          ebnfMakeProfile, ebnfProofs,
          ebnfPipelineCommand, ebnfGeneratePipeline, ebnfSecondOrderCommand};
(* LeafCount /@ res *)


(************************************************************)
(* Modify parsers                                           *)
(************************************************************)

(* No parser modification. *)

(************************************************************)
(* Grammar exposing functions                               *)
(************************************************************)

Clear[SMRMonCommandsSubGrammars]

Options[SMRMonCommandsSubGrammars] = { "Normalize" -> False };

SMRMonCommandsSubGrammars[opts:OptionsPattern[]] :=
    Block[{ normalizeQ = TrueQ[OptionValue[SMRMonCommandsSubGrammars, "Normalize"]], res},

      res =
          Association[
            Map[
              StringReplace[#, "RecommenderWorkflowsGrammar`Private`"->"" ] -> ToExpression[#] &,
              Names["RecommenderWorkflowsGrammar`Private`ebnf*"]
            ]
          ];

      If[ normalizeQ, Map[GrammarNormalize, res], res ]
    ];


Clear[SMRMonCommandsGrammar]

Options[SMRMonCommandsGrammar] = Options[SMRMonCommandsSubGrammars];

SMRMonCommandsGrammar[opts:OptionsPattern[]] :=
    Block[{ normalizeQ = TrueQ[OptionValue[SMRMonCommandsGrammar, "Normalize"]], res},

      res = SMRMonCommandsSubGrammars[ opts ];

      res =
          StringRiffle[
            Prepend[ Values[KeyDrop[res, "ebnfCommand"]], res["ebnfCommand"]],
            "\n"
          ];

      If[ normalizeQ, GrammarNormalize[res], res ]
    ];


End[]; (* `Private` *)

EndPackage[]