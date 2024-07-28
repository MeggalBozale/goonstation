/**
 * @file
 * @copyright 2021
 * @author Mordent (https://github.com/mordent-goonstation)
 * @license ISC
 */

import { ColorBox } from 'tgui-core/components';

import { Box } from '../Box';
import { Button } from '../Button';

interface ColorButtonProps {
  color: string;
}

export const ColorButton = (props: ColorButtonProps) => {
  const { color, ...rest } = props;

  return (
    <Button {...rest}>
      <ColorBox color={color} mr="5px" />
      <Box as="code">{color}</Box>
    </Button>
  );
};
