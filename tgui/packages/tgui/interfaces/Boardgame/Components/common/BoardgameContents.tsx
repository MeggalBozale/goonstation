import { Window } from '../../../../layouts';
import { useStates } from '../../utils';
import { Palettes } from '../';
import { Board } from '../board';

export const BoardgameContents = (props, context) => {
  const { mouseCoordsSet } = useStates(context);

  return (
    <Window.Content
      onMouseMove={(e) => {
        mouseCoordsSet({
          x: e.clientX,
          y: e.clientY,
        });
      }}
      fitted
      className="boardgame__window">
      <Board />
      <Palettes />
    </Window.Content>
  );
};
