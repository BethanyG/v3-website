import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { FavoriteStep } from '../../../../../../app/javascript/components/mentoring/discussion/finished-wizard/FavoriteStep'
import { silenceConsole } from '../../../../support/silence-console'
import { awaitPopper } from '../../../../support/await-popper'
import { TestQueryCache } from '../../../../support/TestQueryCache'

test('disables buttons when choosing to favorite', async () => {
  const student = { handle: 'student' }
  const relationship = { links: { favorite: 'https://exercism.test/favorite' } }

  const server = setupServer(
    rest.post('https://exercism.test/favorite', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ relationship: {} }))
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <FavoriteStep student={student} relationship={relationship} />
    </TestQueryCache>
  )
  await awaitPopper()

  const favoriteButton = await screen.findByRole('button', {
    name: 'Add to favorites',
  })
  const skipButton = await screen.findByRole('button', { name: 'Skip' })
  userEvent.click(favoriteButton)

  await waitFor(() => {
    expect(favoriteButton).toBeDisabled()
    expect(skipButton).toBeDisabled()
  })

  server.close()
})

test('shows loading message when choosing to favorite', async () => {
  const student = { handle: 'student' }
  const relationship = { links: { favorite: 'https://exercism.test/favorite' } }
  const server = setupServer(
    rest.post('https://exercism.test/favorite', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({ relationship: {} }))
    })
  )
  server.listen()

  render(<FavoriteStep student={student} relationship={relationship} />)
  await awaitPopper()

  userEvent.click(screen.getByRole('button', { name: 'Add to favorites' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows API errors when choosing to favorite', async () => {
  silenceConsole()
  const student = { handle: 'student' }
  const relationship = { links: { favorite: 'https://exercism.test/favorite' } }
  const server = setupServer(
    rest.post('https://exercism.test/favorite', (req, res, ctx) => {
      return res(
        ctx.status(200),
        ctx.json({ error: { message: 'Unable to mark student as a favorite' } })
      )
    })
  )
  server.listen()

  render(<FavoriteStep student={student} relationship={relationship} />)
  userEvent.click(screen.getByRole('button', { name: 'Add to favorites' }))

  expect(
    await screen.findByText('Unable to mark student as a favorite')
  ).toBeInTheDocument()

  server.close()
})

test('shows generic error when choosing to mentor again', async () => {
  silenceConsole()
  const student = { handle: 'student' }
  const relationship = { links: { favorite: 'wrongendpoint' } }

  render(<FavoriteStep student={student} relationship={relationship} />)
  userEvent.click(screen.getByRole('button', { name: 'Add to favorites' }))

  expect(
    await screen.findByText('Unable to mark student as a favorite')
  ).toBeInTheDocument()
})
