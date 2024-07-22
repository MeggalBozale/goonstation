/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';

import { computeBoxClassName, computeBoxProps } from './Box';
import { Dimmer } from './Dimmer';

export const Modal = props => {
  const {
    className,
    children,
    full,
    ...rest
  } = props;
  return (
    <Dimmer full={full}>
      <div
        className={classes([
          'Modal',
          className,
          computeBoxClassName(rest),
        ])}
        {...computeBoxProps(rest)}>
        {children}
      </div>
    </Dimmer>
  );
};
