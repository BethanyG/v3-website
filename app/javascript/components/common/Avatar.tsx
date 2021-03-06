import React from 'react'

export const Avatar = ({
  src,
  handle,
}: {
  src: string
  handle: string
}): JSX.Element => (
  <div className="c-avatar" style={{ backgroundImage: `url(${src})` }}>
    <img
      src={src}
      alt={`Uploaded avatar of ${handle}`}
      className="tw-sr-only"
    />
  </div>
)
