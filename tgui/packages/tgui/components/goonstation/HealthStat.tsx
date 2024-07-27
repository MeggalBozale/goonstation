/**
 * @file
 * @copyright 2020
 * @author ThePotato97 (https://github.com/ThePotato97)
 * @license ISC
 */

import { classes } from 'common/react';

import { COLORS } from '../../constants';
import { Box, computeBoxClassName } from '../Box';

interface HealthStatProps {
  type: 'oxy' | 'toxin' | 'burn' | 'brute';
  children: React.ReactNode;
  className?: string;
}

/*
 * A box that applies a color to its contents depending on the damage type.
 * Accepted types: oxy, toxin, burn, brute.
 */
export const HealthStat = (props: HealthStatProps) => {
  const { type, children, className, ...rest } = props;
  return (
    <Box
      {...rest}
      className={classes(['HealthStat', className, computeBoxClassName(rest)])}
      color={COLORS.damageType[type]}
    >
      {children}
    </Box>
  );
};

export const damageNum = (num) => (!num || num <= 0 ? '0' : num.toFixed(1));
